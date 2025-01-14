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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2084927045424qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2084927041200qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2084927040240qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2084927041776q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2084927041488q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2084927044848q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2084927040240qX   2084927041200qX   2084927041488qX   2084927041776qX   2084927044848qX   2084927045424qe.@      ���0��	�����*J��C� c�;�U���A�6J�c��v�`=��<�Lc��b��p��Y���H��0�>�nY�o춽�iW�e07����<엑�sw��[��5�=E�>[�b�ؔ�f�?�R4���jWC?�B%�b�Y�1���o�N?X<��̗a���c�|d*>bYn>�A3��(=��W���ɾ�n ��Y�@ ��wR�3��?>S^?A���þ5���޾+��>6����6þ��%�V�h>�@���������\?��=t�̽q��})-�}�q?���=����'_J>��F>�����%����)?Z춾��C�����X ���i��`R�����O�a0�� qþ�����-<��A��w`>m�Z?�iԿv,��gyP�����?i��>nWӿB����-�|���u6�ü��}�>-��� ? =[տ�3���8�?��>����J�>Lu��]��W���?7��p㼪!�=m�N=���=�Uн7j��=�1�$�p�}�L(��/����=�M���o��F��hf�=y�3�	��<��<�(ݽ��=��	�����8�'�>���=K�5� �ƽ.��=�NF�Z}1=��f�zD�<U�=x��=�&�==�=��Q��ؽqH>�\<�L=�޽Z>�<j[¼
yھ��=C��<Ʈ����p���D>����P{��dK�R��dI�=v��-T?�ݾL>޾A�=�������������f�Z�X��|�Z�罌G>�sA��_�?�3>�*>l�?�i�*�=�>�r`?��!>�{��rS<%��$X=�4��ӽ��5�2��R=��н��=��l�~�=�ڎ����L�<��V��ȣ�1�|=a�I�B��=�g����ǽ�&�=T����I�<!�=@���޽��W�l����׽"^��_/�lN���=Ӫ�=�)k=��>�Fz���=�+-=�.=Hw�p��=T�3�9�k��l�:&��]���k�2�B�x��;�3]�J��iU�=��=�Y�=\�>n�<_�+<�9�<$sp�!Ԛ<h�M���>�ػ�Ә���.:3�?�PS{<u���I������N/�����������<B�-�|y:��P-=0F��"����(��I(�tS?>����
X|�D>a�ֽ*��=p��Z<�n�@>י>�V��P��ߕO<�U�*9����D;� ��y���'�,;��y��r>��<��ؽz����| ��x�=�W���l=޽ ^$�a���g�QO<�[��w�Z�_=��=\��z>�N���zo��<�������;�%����e�?����	���a<U(�}�8���~�:�����P��>�ܽ��M���C���L�2�Ͻv�����<I���ť��������,�=gM�חQ��.L<Kl������΂d���,��(\�
!�n؀�����8=��eYM��ƾ���=�ZżL��P��t�>����O���=�I����wr�>_8r����/�Z��̜<�Є��<ս-���h�����(�����о3<,����>�2C>Z 8�↫�~�=���;�>��>��b�6�V�Ս��Q.����weL�b�������E�� ���˽�~=(�={��=��u�Ƈ=�G�n����/K����=T��k�ߗ���������=����El���90>���i�T��4X�Nn�qtH>�z��ȳb�ܬ?�D���(��b��X��H{�>w���&���Y̻	�>�b>]4�?i�0>��վ���//&�EȈ��<�08��]^����=�A���>F�"�]�?�N-�i_�=�y�W¾�5��q^��	=���.E��1��z"��c9?2쥾%q/��6>�ܓ<j�=���=�7?�ѿ=	½�Q >�N���R��=��
^�-%C><�'>�ý��>Iv>o�>�-?|$~��1A>a�C>���=ʷ>a���,��="�;��Q�>s1�:��>�#f>
�I>�� ?K��=��	�7ڄ>>O�>�.���?�>@�>{p�f7?���=�TʿGC�=��5��.��Y 1=�'��C��*��3꨾�+��c��=��Ծap��ԊW��	1����N��1���y;z4����>{X�����m<Y�����ʹ��aŽ�M������t���=�?۾X޲?��<����(��������y<lG��/=�?O2�<Q����47=�������<|>!�{�ƽ�oI��ƾSj ��|!>Uñ�P��ʘ��ٿ�����f���g��3�>Q�b�&�Sx�h͔��}���=�꿹/Ѿ�>2�����n�$>=}��co�������?�� ���P��죊>u�=Oځ���A=&����������<P�����<��>���^����eT�<`g�=b�����i=�l	����=Aiҽ�Aq�s�=��=�8��:MJ�C����X;��4�y�&��1�=\�3�h�н�}~���>�\��=H�"�h꺼�p��h��=��"�$'y=k=g���8ܽ|�.=pb�����Ӈ{����=��=����N	�d�U�%�׾�ӕ�煛���̾���&9�=�2?�鋾Đ��qH}��V�0a[�z���u�B������r���>��EJ*���[����?P�">e䀿��m?6���{=�;��֧?�KW�����:>��`�CK��sF�mY0�-�/>8ߛ;��D��5>��	�����B�E�e�y��;`��=e/#�Ħ���:���;h�>I�o=�
���4V=Pa<l���Is��J�=����z�<���I�ѻ���<�=�Ҝ��߀�w���7�&�;,���>>��6���=q�]�>��3Oz������I*��伆���&���ް�=8c߼�9!>����H"a�e)���޽ӆ�
�B=e���^��^�������OAV;����r\���T��>�����'���;*S%>[�K�0ҽ������ɽ��پ%�=%hɽV%}����=A*����Y�G��3y<7�[�Z�޽w⇾2��=Q��	�"r��X���S���>*٨��X>(��J��= .�=$���Wl�p��t*�;R�q��1<� �PE8=��ͼc�� ����� �=�ſ<F�� ��������|�1�<��½.�>���<ޣ��c�=荾���>[=�$�i=�����(>�|�=�t���K�K:{��ȥ�))�<�WK���;>����:�H���gYܾ�E=��:��ӽ��������Ƒ�=MI��ei{�*�H?��H��]����>�&I�2��\P���d>wF���d�=�墽���֮�	��=��`=%=��vֽں���5���H,��%�0��x,��M�=��<#�/<X�x<�۰=:���\��o����=��x�7��n<漮=���=A��Լr((���=�`뼫w�#T𽦙>5�=`�l�*���a/;�)�=n�K�a�ƾ5Ǡ���c=�$��/3+�q���7O�<��=L��=PF�� ��y5$��s�d��wﾴT�2��>eX	�Ms�џX>�8Ǿ�:*�UAD��Ϡ���#��G�=|��=�1x>`ο�2���z@�U�����=�;����ӽH ���>��u�'=�'�=�@��G><3<�s�$�ɽp.4�t*����=��%��{`���V���=n�׽%8<��}�==��<H�˽&���O�~���@�m����%6�Bt�iD����=����f9ܼٓ��O�;�D�P��=�ļi�\��P��A ��Hx�b/�E�üp�ٽ�T.��!�����SY���z>�^���p� 5��8&�<	4�>���B1�L���J�����>AM���+�b�/�J������z��P=�}���,��=�W�=��="a���N��qv<�l=	�=��f�FҽU����?�>�*=$P��mֽW�k��ј=,=]��D8�	�U����<�i��ZK�`��]?O�#�7��DžU$G��Rƾ�	?��޿v���3�l���'���3���<���M�R��Ó;��=��,��x�?YpW>9�9�ydT?�᡽Z��-�/�o�?�)ݽf���Q���$s�x�N�NqW��9>R��f�H�&����;;r�2=���xxu�=�z�^���#q�}^��� o>.��=�iھ��i��� �μbzU����岣�:ý�m��;�*���z�]?ו�Y/񽩌?.4���C�u��rW�>O�Z�g�@>�h��­=���&G=h0
�|fP���=O㪼��$݉���쾯�;�9'��L����#���h>���=�><p�c3n�%��=w�"�G���V������F>�Z���C>$hx���w�B?}T���U��GT=S���k.�;C8=|-
?��=�R�<�j�#c<�C�=�厽��L����3��8��<�V��?�6�!��Zµ;���V��=��	>�E�����[����<�Ƚ��!=�Vּ�I�=&���b�=�9[=��iZ>����@L��ȭ=����,�ĽO���y�Ӽ���=�6P��r�����@Et=��N=]�=���=[�;ϩv�B���B���>�؀�b2ͼ\�>��^��Ԝ=�)<�5 ����=�D�� �T�.�ܲ,��m����=�%����&�zE�6;��8��<��Q�j}�=I�q�Ҁ�<�={�+��P��W�4=<�T�W�L�Od���o�p)a�)�ȼ�<��A�*:�=$���:y����5Z���1˟��I�?+��܀�= �z蝽��?ڪ>Fl�<~>J��w�-��>���R>,*v>K���M=��ȎսP�O��Ͽ��0>�%�5�����>�����O=;(C>`a��8>��̼�ڭ�MQ�=��@=�<�=���>���>:e�=�1�=�-˽O�Z<b$g=� =�<�]@��`-�>�c=����1�q��{=M?�0�=���-u�>b�>�!�>�H>l�����?r�8��ԿV:>�����ȿ8T�]H>� =��1r>k�9�P<s�sq����s=Hv��#瑻���=�G�L6�=`�d=��T����໲�J �=�]���G<�S��=#>G����K�>�H�=���:�ڽ��@���M4�O>HzL=�����.=;��<��ս���+>t<�=�W=�p�=�k9�G�/�.5:��=��W~��I�~S����^�6�jI̽��=1K��1���Z�>.s>>�z��=X���)����=Te���r)�q���V��"~��a=��v�ܓ�<��>*T�;�N�<!��*�=�տ�M�?�B�=Y�>��ҍ�p�ͽ���<�ʸ�k4�����K�����ܼ-����Mý��`���o������*����1�� ���?�<<ҝ������Õ��n�U��>=�,���B�}�(�u�T�X�\>�	>�W��4_�>���=�����ܾ��?.�>>`9b�`璾-�P��.�=+�<���>��ӽ�t�Eߺ�῾��E�U�E�7��BN��\�"��#�}!��+q>O�k>��?�H�?��K��T��|z�����6��>��f<u�n���ˆ=�q�7�$�[b�?:����t�f�ľI�)>+�?OPX?u�
=L�޽@Ǎ�R�5������r����׀,�8q>,6���难9W���}�#%��7�6����%���/U>^5�>th�>��g?�U	>6ۼ���0Ϝ=$˝���>ew=�� ��{{�� $>�]̾��羃T�?�젻�w���;����>��>�\J?�q>T�
��(a�@����?�$�¿��\��Ͻ �ѻ���=�d��&0���ʽQ��� q���w�X��!j��U:�^:�>!d3�d���S���)M�����:a��)�4�򼅗�<�!u�̔��P��o��e�t�>=@��$�P�=7ܽ��k�e�-?��S��׉�8E�e]�sXy<XQ���=�	;)����~"��+��Z�=�|;����gSk��o\�d�%��H�׳� z�>xQ>)�3������ͽ��c��`����W�	埽��z��<tR��?�����ƺ=9�<J����S_�F�!������y�=��;<׾O��*���{/�y�ܾ�߽�]�=�׬�����xR=��"�1;W�T���{����=����� �\�8|��V��|�<nw#�+����2B�ֆ���sþ������=�ĺ�>2���&��4W�=td��C� � =��I=[�����5W��(=�[<i�J��G��/�xF���b�(       KT�2 ��Lg�ߛ(>�Jڼ
8:���Ϳ8ɿAN`�۶��n�=�j�"�R�� ?ܣɿS��Ų�0O_���?vG�?�l��˿���>}pڿ�s��}➿��v>�t��z�7�z����?ս�>"U������;:�>oŻ>�Մ�0���x9�>/�/�(       ݢ����X�5��?l�{���׾��ܼܿ��3>=��=aӾIQ�x�<�S?�����Ӿ�ݖ�>�?	k.=-�>�(\<;\(���U���-��Y�=�ң=&�y�+Go�H�潔��<��c=�����?�?>o0��៾�j�>?�
?�]>�Y��Q�½(       ���<~ܯ>cG����u�M�E���M�u7���x�ڵ��,>]�"���;}D��UE�d��>�����R>��佽r��|���b����07?�K�%��5���<�C�/Ծo=�Yi�%�@?�/j��?�)�\�Sn��p��� JҾ�����\�kmE�       9z�(       7������>2��;w���(��;�ƾ �ľ�=��,2�8��>�f�>�9O?JP2�f�޽@�)?~r�>y���>k���-�>Z�>Ղ�K|�A�?J5�e�Ѿ��m�*?���:�L���d?�c�=�;#<��&?�9��L^��`!�;F%�Wm�dȾ