��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   1552210527072qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1552210527168qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1552210527648qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1552210527264q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1552210527456q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1552210526976q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1552210526976qX   1552210527072qX   1552210527168qX   1552210527264qX   1552210527456qX   1552210527648qe.       �$s�(       �.P��'�3�(��J=�i��=�, ?��"��<���{7�_=g=P�K侽3k��Ǩ� �����W���I1���c?�3J�ݔ�=A�L??ͻ��
��P�pm�F�!>�P�>�0���!�?"��Ҁ��v1�2�-?1�6?�aڽz��9~i���پ(       b�=�q���?X���~=����X�>Ӫ��\��+�4^�=�Ѿ"J?ĢP>�&=E��v׿�[���������=F��>@���=75?q� �ͧ����o<�Ζ>Q��=u�2>4��:�C>v�@<��U�H������}:�>����ֵ�A˿(       m}C?y*?������<?c1V��t
��풽��>4k����=������=�.�ǆ�='#O>�ן�!�r?��?�]��E��T'=�S>�c�>��>�s�?G�v?^�>ԟ߽I���T0(�Z���۳<���%�>D���?���?Yw�Y?=(       ����*��0��>���x�P�E|��?��-��޾�re>~�=��@?Y�H>ɋ?���>�S�?����d��XF�>(��|kP>��?ф	?z#2�2'�?��"�bpo���?�G����>�_d�Rk?�j;�M?<�?t༂�~=�.���j=���@      �f��=|����x*�o.̾��>jWѿw���A���AS5�3�<u|�;q2>�H�>��]��g���A�}S:�ފ =��5�ja�ܹ>6Ȱ=kp�< ���M�M��=�},>�Y��&?��ӮF��G¾��s�,M��n��}�7�D�/����tP=ˣ����m����>D��J̿������??Qܲ�I��2Ϗ��t���[a>d�>�JD��. �#)=�[���������ｕ�G>a/��!��~�=����=5��=�����������S=�B`=�=���=p�	��w�=M�h>lK��O�8�P�aR�W����� �J<{�??}>A���L9>�B
����=���=�:P=���>�mR��]��5QV=�
�>f&p��3�>	���`��{ۉ����w�>��=�v�=@Kj�^K>ox?�KݾzE/���>�o�_��=�ؿ������!Ҡ�{?νq_F>s���������S�����՛>'똿q�~��3ܽ�|뽋��>$鶽��߾\�(?2�������Ѽ�,(�9�v�8�O�F����P?Xxu<O�;�M���u|-�����Ô>Vqھ�>�g��hW���%�����]��8�N�K�+��b���-��>�k��@��̽z
��Q{�8W��)=gU~=
^��4�=�"#=��f;�����<���*���ih��Q�=�W����*=3���|[�� ��;��F�����Y��ae��X��M�I=KK�sݗ=B?�<��򽣬U��<:���c�z袽!	���S��)?=૪<A�B��=B�=wʽ<���pf=Y>�~d=ZLؽÆ=q�g�KL�L��A���[�/=���%��<T=�)7�@^<��=t+�eD/=KN����p2>��Є��f>�6�<�`����h��:�0�<�n����������hj��ɽg/���>��#>l=`�<&>^�>@)�>b���Z��=N� �MT��z,��_7�?��-����^�ޕ�����=ڟ��n�&>/BU�
���S��>��<?ɼʾ�fJ>�@��w�����>�≾�C7�Qw޾z���>>֜�:�� ����̀�=�)'>�%���'Z�..i�H�տ�f�z��b|H�@���Ω��p݂��Q����鼟�I��&/?\? 3���J���S�*P��q�������\E�>4h����A=�k���r����>���xU���6?y2߾"ÿ�־�N�mc��@����H�V��~m�[c(�j�>��C�� �|�,36�<}\��X��������t=�K�>ܔ��1�<�o�?�[��F�>!�<���>�s۽�Z�>�>k`Z>�r��f=w"9?����m5\=�a�>�;#����ܨ�?'{e����=�P��>��O>D=�G���[o��K��G ��-���ҧ���ٽ˕�����)������`SA���
>�،��k��bk=�f?R����V��}e�� �I����f�'�Pgտ�3U��t��"��@?�ef�*�Ӿ"������>k����={K1��z���k�;�o	�M�?�=�3���!�����V���(�:�e� �q���ν�+�:������=��#��M�=��>Ç
��k�Z{E<< ����-�����><�5���p�O�弨琽%�?��@üi<����^�lV��+{�N^��{���E=���BN<J�ό�̹2�ׅ�;�]=)���d��i]�A�%<��>;����+�?_�>����zs��KJ�+��=���y���p$�2*|����+�=��->�V=uP������e��AM��&`�:�7�>���=Z�>3Cl��G�>���?4��gՀ=`�D��cY={�cݞ���U"��G������=���>x��=*�ڽ�_��P�=�?=�+�R���\����;�Ú<�|H���g=�˳��1v=aO�������R�Vc���	=�D*�I� >|�/�����j�������d:�lB>,�=�D�>\��<L&��ւ�_+d��b���>�g'�^��������E�=�"H��^>>�>IGk�lw��2�=�t<�mA�{vl>z�ݾ��D?fb"?��ȿ5Q���K��Y=���e���<4��=H>ť�щ�>�;��V�����k��=ŇB>!��?7
Q������|������Կ2@��(�������|��I�O�@_�<�e�<`r���5���¾`�����'����=M���b=�Ž��t?|��4~� A��*�J�t��	�>1���K=y/ϼu8�4�!?\��ql����7�2+�ݲ?W��<�g���Nb���ȿ����^E����H0����/���~?���Ð�=>��=S�G������M˾�}K��ᴽ8ݻ���?��?�<�Y?�jʿa�?ƌ�>�¾��R��&`��[>�I>s�E� �3�R?�]��s'�Y	?����<��|��=���>���8�>�̾��\?��Z?�&>�� �+秿LyA��)���2z=��ܽXm�9��>���=Mz*�)W>8�8�ژ}>z�����m��J���,�H"B���Z�"��4��=ӱ�������S]>8#��ٕ����y^�������yQ>
�Ż��-G��￾�~�����}��a�2���-�ʆ�:0	=��X�������=�m��X��<�F��li�<vڿ��#= �Ļ!��0z�<��
��i�>�?}%�����G�������E���N�$���g>�q>n\Y>m���甡�ǭ>�GO>8�*��>W���\��������4q��=ž��&�Z���C�;U�׽㘪�[F>p��<��={8	>�h��2.�>��	���c��k>������>�&�>'��=3x?��>F̜>����󟾕�4�ٕ�>���"*�>�_�>l�3��}/�5�)>s� ><�f��޾V#�?w�>8% ?눴>�i�>7�=K�
?�d�����G=h@�l��([��X�T=�«�J�t=J��X�����;���=����`�9���Z��걼�.��=�2彝���� N=�O><*%�z��=���=��>��ݼ𒤽o�=����=6�"��})�'��|��=�c	�h����'=�W>�63���8=̀ͽ�*���]�������P<4J`=�W'��@���a�_�)���<ع龊.����⽠�=?>$���ξ\��Tv�ն�$�(�o朿2�d�����/�8?Ik��#�ξ��Y����dD����>"���O�v�c�	�����ÿu��*�5Z�M]��$S�����p�%=a]��NU�?8ֿ�(��P��jp����=zfܾ�������7k?�꿾27N��ʽ��F�����=�$��ɿJ��=0��;������?|�����I���R9>��Ψp�����7���ܱ��HI��(o����H>Ҵ��x[��Ѿ�̴�w��d-ս�<C=�`Խ�6G���>܊�U >�>)A�>���>�s��˼�e->�q>���>TMS>؜??B羝��<�
@;Kf̾�����>���>���<0:"=�������!a=
֐?�]0>���>��ľ
���/���>>��>���=�9��� �=���x��<��W�!��=Z����ý��F<�ƽ�=>�G�=lw�>�% ??�������I.`�b�H����= 2���]� �Q>�>_M�=.�ٻ<��C�Y���=����#G^>AMB�q����Z�|	��I��E���K>�)��U�=XUI��^��>�;u1?�= \
�̪����??L0C��e˽�	�'���aZ���!>ib˿0]����v�����͕ľ���^�=ӬϾ��Ծ:��>x[Ӽ�R^��J����>�M�^&��%���?�u���"���ew>'a>�@>��_��ԋ��~��ɓ�>,���\�~>K����p>��>�?��[��o<l\���
?]x�>g�&��?��$?$��>װ��N[����l������2?��ק��4�ܾ˺��?V�?R��>�������>���>]�?�J��v�ſ�'���1�>Z����Ȏ�xaG�uh߾�3�:�hc�� �;c	|�v�=����Ft=��ӽA�Ʉ>�����"����>`v������ϴ><|��8��91�eʹ���>W$q�h/̾L������`���n>��L%�>���������y�>��,����,�Pt�<l�ٽ�>�$ƿN��=ݭ�� �`��=���y���Y�ҞV��k��8���%?�'�4��>�[?G�=���<�hj農�'�q����ZK�P� ?Wc��0, ?��+���这d侕��>i"ٿԫ?p6��]����2n��C������Օ>7��=NHH��Q@����<A����G��Լg�.�,�X=C�;�Nٽ����v�;8߽T��48>iן= �L8:�����\=rL�=j �='R��L���	K�=�‽ H�땽F(�H=A)�b�s�̽6'�==j��V��K���E�=�/��Y�Ȋ��G�ýd��=�
��7�=L(�9���fn�Co��)����;�� �=� ξوT�IEY>a:a?-�X�V�"�<B�= ����I��7����B�������g���h��>*{��ȇɾ)bս�T�=hb��ْ}>󥒾�Ë�Þ@�6x=��˿n�����t@���������W۾�N�=R��>����>�u?<��>Z�����m=ԉ����J��X�>��C?Ǵ�Ig\��2�=v���.�t*��lӽ�w2�c���/��>{*>� ��2>v8������?����?�<�՛>�=�ǽ=�l���<H���;d¾�7��ͺ�v�U�@�V<���;���۪=0�?�ԓ>:(�<�e�=�<<�B�>U��=Z���#�>�=v��=�s��HV�QP�m"?����j�=�= ?=Rʿ]V����&��^!���l>N�>I课{nݽ�R�?"$�c�ɽ	��=����, �Z���h��j���ᴽ������=8��<�������T ʽ�m�=�s=Qn�=QR��Q5=[�P��b;�'�˽�b��S��Ê=��=*�¾�m��*X��Dx���=;��<6#=!CG=M45����Njν��(��G�P���%9�D 澲Ǿ�� ��_:>b�ɼ�Q�:}9=�������	>W	��.���\=��I�@ql<dԀ��i�=��=P�\<X�ü�:伒j.�e�>�t\���zړ���R=c*��>���TGH�}]>b���g����=�b�<�)�=/خ�����D~s��v��pe�<���<����Uܽo>�c�0j]��h�=k�9΋����kل�v����!��t=�xt��#?z`��
���,7���ն�f@�q�����Btn��n&>ݫ����>��/�˃��V��M�:>�x�=5�?�^�Ȟ)�8w���T��U��<˿fȍ�O�=>vl\��%��[:�<���=��I�L�9��2>�{�I=j D����=P��<��J���=�6�
�� &=��gC��Z�����e�����l �<-���5Z�]��@q�><<U�=��a�=��ｙ��=���=�߽=�A$���;p˼^�
>@J�<�Y��`K��m��$������=Pb��v#��0�� i�=��w�o��ذ�\��)�����Kz���ڽ�X�8bh��N��{�U�M_V����=cw�����~��V��\=��h����J��R7������c`�����{ѽY������=�)!�T ��:�� ���	���v�p%+��=?x�<�L4�l+��m9?�W�v� ��Q�~�O��>��˾@~����>�>	¾A�Ͼ" �=��H>�c�?�S�V�a�S��j�;���JLӿ������y>�~�>:^�>&�>}�=�%��X�>l���hr�Z����5z	���1�h�漲J,�m��5��; r���Ř=��-�(/�@BG=��;����|<e�	>���� ���>�2-�ay���Ž�sN����=������>�3;��g�g<�����<o:;��f``� ]�<�[v�;�=�"����xc]��(�=3��<=$E����=pN��e?:���;�;>P���={�>Rؑ=4�0��>f�������'>��@>�^W>"饾�qX�8+�=f�.>����a;>�?/��*�a��>��/>v��>f��ur���غ;���]�H�g��g������g:���