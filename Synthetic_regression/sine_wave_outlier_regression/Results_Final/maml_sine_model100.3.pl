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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2170595022960qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2170595026992qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2170595026704qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2170595023728q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2170595022768q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2170595022864q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2170595022768qX   2170595022864qX   2170595022960qX   2170595023728qX   2170595026704qX   2170595026992qe.(       ����C@�^g�U�?&��>�*Ծ���gl%���K?h"�	�?#�?��?�J(�~��>3�:?2�'<�B=�5�ޮ�m���n�������8a����:��{��H=+?:.9>�1�������5X�����?��w�!�?��)���0���2��ˈ>�If?       �W��(       w���.���Wǽ~�޽��U�J�,>zn����7NI?n��>��,�E)'>�"A��1�=VO���T=�3^?I6���3�S�E�$���J7�=`��>�龆�%>�(
<!7d�X�o���c�<_�=�+�=���6��=�P�>.��>�Hӽe��>��7�ڷ��ΐ<(       	2�v�yrB����l�x�%0,?��>��=*޽5E?>>1���K��HӾ��%���|�ڸ۾�_ֽ�P�um?�}ٽ��8���>�:��m/��:R��OĬ��.j�W��>I��V�B�W{F?0��=�:D�,4W�v�?��=%��=���
�>@      ��>x��=��B>���>m%a��s�<ޯ�;�굽���?�~�>;x>"�޿�>� b'?�<j-b?��>
!��4�ս@���f�<�r����J���ྑ恿$�)=�R־Z$��A�$������Ѧ��J�=0ͳ>~!����C(�?ǚ�>3�4?>K\�S�@3ߐ��
<m���AU&=d|Ľ��$�٤�b�d���y=O��=sC��<A�����<�� ��F�<��X=\/�'���<F�T=@����?�!@��Ӽ��缅�(��;P���I<��<�1��䌺�a�<��x�����D�:�|�O��=�H=)����,���=�.Tž(�����R-��5ľDw�>+w���J>ĴɿXL>��=���bΙ���bX>V=�.�x"۾��>*�G��у�N`����>n���#�>��3�<�*���7��>�Ǆ�D�G�v�O�Aֽ��I>t��>y\�����)�?�u�6�:��ϝZ���+�<.!��g���?�4�=����� �/>D��Hq�>�R>���>k&�\1<�+�?=!�4�VN$�p�=`S�"�> K �����J_�=�B@�y�����D>徲��H����>^M�>�ߖ�q�=|aQ��{�,�R�C�J�}��P%??�>��>\B=���`�?<=4f���H>p�G��U�P>j��`��<�>�=,�}�	���3��[;�`�=`:>wf>�R�> ��������\�7#�rJ=_����{%�G�>!�f�'Ē=�*�?|�_�/tݻ�(�횆?�=:O�\=�=�g�f�>Ўn�0s뽹vi>��>��<���Ծ�?J!��'5�( ?
��>Ԣ�1�=k>��=�ׁ8���!��f�9<��f��(ݽ����N���X��,k�>�w�5��D����yQ=i��)�g�������єb���L��8"?x��h�6�w��RO�����'���H?�vC=�����Y��T+�z�>�\uj�r�þW�Q=� ��,� t�O
 ��[ؾ9&^�����kMu>@�<��ڿ���:*���>l�I�\�"���������J�U<�3���<�a�����rV�Z���t��z���޿��+��1����(��|�>9�;���>D����#>�3
��f�;ĕ5��V�!M�=QȾ�'���I]��]/�W���k~�Z���K_>�E�=�>W���B�p��?>��;c�<e׾�q�=��T���&=�M�WGоWN�>KӾt}9>!� ?E�?h)�����fR�=�o��?jp�-{X>g ��'���~���oY�eL����>�#'��Q+���b>.�_�+t�=�c���M>J��=�닾�?� ?�,�L�=��>��Z����>�
>��?�4>��>>��>�%�>���{���?�L�/��l>���H����>�d���{�><_�[P<
����e��U���}	����@>��Ҿ�|��*,�=���
��0=1�Y�Y��>!�ƽm˼1r=��ھ�
l�Uw>�]��� ;E���ՙ3>�֬����=�B�]�Ѿ��a>t�h����읐�3�h>��b?��>-4��Ã��Y���x�;C�>]m>a^�>(�?�j?�>* �u��<�{�>��>��C�S�>�=�>e"ľ�,<(M?��B��ƀ�?�?�TO������>�'�����:?
7%�1ɑ>�1���?�Z?Qza���3>Nþ�-��y������p��?������s���DI?Kt��x	�+#��4ǿ�ѿ�PT��.���Sȿ��;��><�
?ۥ��n��KN?<��S@�8��r?	��Tn���Ѡ�d�m�$?(?_i⚿mv��eN?�����	��˓b���%>@ظ=�:1>����}�����>(t[=�~>��<`�r<��=��>Z��;uZT�	�2�1��Y� �&y���d���>��1�-��>��=�>�<yE��S����=}�>��̽cE>\�h�Юk>��I?���<Z>���C�%?��������=�^���� �P��T~���~=Q1�v.!>l�9��#�8�ѽ�EѼ� 
�U�����=I%>a׵>�Z��PĽ�dR=6���=�(��K༔P�=��>��=p�ռ��;����h>i�����]1�<z�?�fM>Ӧa�F�W�P>��I�Nf�>E��f�b��<n��Ǒ���ſ�6>w�$>h��M�C>3ܩ�ub���d*>S�/��i�=I���F�=�2=�˽���=H�׽�,�>�K�<E8)>'�H��k����޽&��={a�[�=~���y��=��> ��=@:7���s@?�eG����Ʋ>Z�>?��<��<>���H޿f4a=ifu>��>2�?��������>4���Ŝ�>���=V����9׾�<�����ݡ�(9B��վ���>V�ŽBu=��J�~S�@�?�,�]5�ar�>B�ξ�!�����?����7l?����q"�?�i<�rA�����=�VR�q����G������e=�m�ML����:P��<���=l�"=JC�=#��t��=�C
�����V�нj�>H������*��o}���=z��=k�0Tl<�����佺���ˠ=J��=�'��U.�=��0�/�/=�I-�o�<���=�~ǽkE>��O���>�?���A=���:ν1��pl��]�=�BX���K�_��w�uz������Bv�Гp�1v���^K�=��[��")��h�d�F=m���G�[�<�렻��K��� �J�f�)��荽�%����ý��Z��q����>���>����Ͼ��Ol>9>�_�?#��������&����i����m���@������E��z��qڽ`����}�8�Z=�(h���>���=��پ\�? �? �a�lg?:��>�ֽ�˾��>����I�=�H?�`��p�Q���r���=^3f=最�6�o����9�½/��4�kE�����B���=!�F�B=����[=��=G�<5�cm�=(-a�M	%���=.v2�?5�E�z�Q��3�'�^�Z�Z���Ƚ���5� =V���I4��W2��2����!���W�*�~�^&���=��>3G�������f+�,�#>ʖ(?(��P�c�f��ݩ>����T��������b�>��|��J{�����u��s��w����l?]>��>�e�C�	��ܼ��a?v���,�ϽzJ�����j�?N}��6m?�?����?=/C?�%!�X-����3�+&S=	׾��"�p��>$4��'�B��>�����=y>��H>f�,?�V���>��t>�1 �݃>��Ⱦd��>C���WĿ(h^=��J��)���n��#�<|�&��hZ���?������Б>܏Ŀ\ڡ��ᮿ|�Y�T@S�m�=���8���K�FzI=�>�U���P��Ƽ �\<nq�=Zߺ:� t�ƽ|��`~���4:�~j���={Ͻ)ӕ���ռ��'=���c�B� Q纒ҽ������P���W��˒l�/n��a����8�=@(� W�:	�ν�mv��]��{X<�A���{�=��+���+�pl�<D��e���ë<⣾=�د�@V��"�<l����(=&��`��=��"�w7��F�����������=�7=,��=�m�����<]���@=S�(�,$�[p��l���'�=���=c���A��B�2=�E�;\�_�x����	�8~Z�󄓽v���:��H�>����
�r)� �W��>�Eս�r�=C��=:%=ɘV���=@~ϽW�=��ܽ�1��A�Ҝν���;4��A�����m�����<l<2��Ev=��m�ż�`�X��:j�%�{�=���<�G<g�����x�f!�=��;��B��%���<>X"�lY���d^�1��
�����<��N�=Ə�r��=��׽@~g�,�)����<�h��O�#=F��=X];��Ew�e����<�<��:����<Z�6����<���=p�^�i����6��>.)j�����{?4^�;�Y�>�?L{��)=R彾3,!��;�u��>�|>6(>?{����,?St�?�����>"��>���>�_=зؽ[&���k=�V�Ȕ�<*�<>e��=�D�=�tP>)�=J�=���=�:��}]�:���in�cf?y��>4F�>	O&���=��N�c��>�}�>�ح>j`T�2�p������eׄ>���>
 r>��}>��?���=e�C�|>n��>��[>�R�<L�b>\����>"^=$t�l?����*F$�9۴>|�d=f�l��8�=E+�=S:�<uwZ����=��?�;�=\�?�G&�z��=�T�>��G?�ӿy�.>O��R鿟�>�̯�K�?��ľ�[>��=�J=?Z�>&��v�g>G���Mo��ٌ�=��4=������￺^>X�����{zo>�Z��_>��0fu=I�>���>�H3��ҫ>���,?�.I��G?���>��þ(���������>%󠽬|��.=?����ܡ�v�����=��%�;�t�ֱ�>�?�����>cA?&W>�FH>�����4]ɾX�R��=� >r���zɵ��Q��sѮ?���J��=�
ԿX�!>|��=2��ҽ���=(RI?|��=IJ����=L��=�>w�ǝ�<#*w��x߽Xļ��/���>;l����6�=5�>0�˽���=S�<�F ���H���	�_o �И���+���\��E�<�R��R�ԽG�2�k��=��=��5��q=�d= 	\:
�����Ÿ)�Vɞ�0�˽J�8�S�g�A�>���>��W=�^�	��=��>����{>̿�վg<�>�:Ⱦ&�����ƾ����UL����r��ԁ��f��c��#=`�+>3?�����G%?���JW�F?��X?yؾ��>r�?8���@�e�e>4s ��(�(*b?`�)� ������>9�M�D���G�Ѱ��~������-�?8g���r^����^ ��x�u��6�ĕ ?o4�>o�u�Gv?�u?�0ǾZ�)?����S�ʾӪ	�c��?.D�=^�׊i�)�\�ַɾj��?���7">��|����Q���bP�*�Q�����տ�=��mQ��i��.H}��|�g�=��a����A�2���!��eм��U��|�=�<*��p��:�9�����l�:�; ܽ�A
�������C���{�$�2��+8=QB��}E��d<�W���X�=,;|��b�;V���9��1;����=�`���Pj��>�K�ɮt>"�=k��>�$��a�=x\л����;]��ڧ�=;pr?�*�� �>���	�E?�Ƽ��=E�>zT=¤=>����N$>6�>�'���1=���<V�ܾ��9>�b�����֝��<�t�:��=��>���]�<��ż#���Y �q���y >��=�п�>f*ڼ�BK�W`=?��3�mp��j����Ӊ�jC(�H��U^?�; ?�k�5�>� ?{����>C(ٽ�9�>,�߽�!�>M�>k�Ҿ<�V<��l�a�;���A?���=��ѕ込C>Th��Q�C����>�ٿ�I�>�m���O���>徘���D?�ؾ(�&�uȬ�o�w�d�H?�dǿ\B���?�E�?�{�>�ޤ�HWr<=0�>�Y#���=v�}=�kY=x�Q�a|]�=�>�2����
��F�g?c?>��؛��I?�h�!c�>�?�������>7ٞ��X>�j.?&����M�m�V�����n���[-N?!fI�p=>T����� v�� ����1��o��r�?e���5.����$���ƽ���<�J�m��_��g����ӽ��Z��ݥ��O��;���ف�%L���	?��=���=�<U>w�p%�T�=��}�������=�ğ>�W�=��Ѽ���L'ܾ��(���{>}��>��j>^�>��?J��U��� Ž�(�>�`>��_<�]�ӽ���F=�ř>ڽ�=	?�Ƶ�{V�����>/!�>#:����x>��>>��c�d}�=�q�ڠ�>���=���?�T?���Y���{�5>���>��=I����g?�k{���p��ͽ;�>��>xXc>)�q?�_^>�&��f������t����D�]L]=*�o�Օ�R��ڽ�֓�qsM���F���>��p�F	h��K>�#
��"���x�?���A>�>�!���5?(       ��?�`��:��:�&|>�u�M� >`���-�>X�=��Q���>��>��~�)
�=-�D�o�(=���\!��調��M�!��<�iӽlE��=@�t�H�a����<��d<A[=��x=շP<��=%�Ͽ�j���N>4�-��;<��3����<