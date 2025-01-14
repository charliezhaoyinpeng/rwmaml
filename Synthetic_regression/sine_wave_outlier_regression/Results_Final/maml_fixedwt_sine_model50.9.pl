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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2085153171968qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2085153177632qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2085153173024qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2085153173504q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2085153175232q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2085153177536q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2085153171968qX   2085153173024qX   2085153173504qX   2085153175232qX   2085153177536qX   2085153177632qe.(       ��>�lK��#��� ��s�>
>���>^3�<{ǽ��.m�+����\�V�>�5�QI<�ԉ�ᶡ�_]��t"�^⃼��3?��?xʟ>V[#�BtɾU� ���b";���Ծx�>u�9�rf_�l����X�>&���XD�;��[���2>U�'>��H?@      �W-=
��=�gO����<YX����<��"=��*�$k�8��=�P�=Ö��ޮ��CD��q����̽�1��CA<��*�E7U<�E=8�P�=<X����ko�<%ܕ=$M��b����B����<�����������ʽ�=�R,�T-��ٟ����=ƫӼ%9�>���e�b=�W=�7�=򱌽�!t�|�!=L�˼�G�� ��D��D�=�����������~�<X1�?��ozm�7���s�&<[B��|� �O$����P��[Z��������V���0=	��=��;�!����2�?n>�AڼwTe=�M.��܁��L@����<�D�!	��,���ϼ�I=�D���a�O'��F�<���;�o=Ǧ_��[�=��A���=yJ��c=j|;��'��8�Y9½����(<��<J�s�H*�<���������;���w�=�&.��;��[漎���TCr�wy������'3>_�����=on�>~rp<u��GS,��H�R�=3J�>��2�o��=_1���>��>F��=�Nc?�S�>}��=����:2�i-������d�������>��H��f��!�=��L>��>rb�>.�O>(�	>vu�>�C=߿�>�37?�, >���C���j��A�󽁖��<����=�)�������u��+1���ཚp�U��։�:?���>�~�����U?����P��U�ƾ�6�"K���&�칑:|�D�p�'�P>&����\;��q�{�
������,��nxD?A"¿�举�7׾ ��<v����I�����u�=�K���¾�����0�ü����uB���辱��B>�罃죽ۧ�<(��<��?�O���&������f¹=���8��>d��~�<���<h�=X�h�����o=,ÿ�:�Ū>4 I?��=sE��%o��檟�ht��C���پ���<�%����	>�.b�a�\��h�<�=\��)W�&/�������dо�Za�A?����?�`��_V۾��־)®�)�ƿU���ź��[=S@>���7���$�Ëb������h5b����?tl�>�~�=�É���g�ѳ{?� �<�W����S�>�!�M:�>&{=��Ѿ�=�����j?�vϽ�꨾�����3>l�Ǿ*~g�-Ͽ�n��r*$�7][��D8?�j��#�	��6�<ѝ>��K�y�`���Gw�Քپ�*�bg?��l�Ip����i�;��>{�޾22�x����\н2�����:`��;%��>�%�W�>��ܽ����;-h=d�]�cܰ=��L:v1�?&6q�{�=r$]���v>�9L>.[�=ߟ�����<:h<���O��$/�ߤ���������BIR=Ll�=�_��X����඿�p�>��H>�6�>���<G?x��L���-�I��� ��������?]��=rJ
���r���g=��i*�F��'.�K3��h��Ǉ����?���=E�Ǿ���Bh���d������`��������=��<�ZD�a7���<`G�f��f͟9�|˾��ݼ<�N=�����x7�,��>�P�=�WG�B����<�Ʉ>��]?����+�=�3>	6q��`?��
��ѿq͑��G���P�]��3o�n*
?�lo>�;$>[�>�a��&���OD;�p/>�C��������Z>3c�l�3<GYc>|~�c�>�b�00�V{�>?����X4?�	?<�x��*��p� ��(�"D�?�����5��t>&����
�K�Ҷ��TZ�����mv�n2*���U=�-��]�%����t}�>P���Շ��0�=uA>:5��o�����U�¾;PF�B˾�&?�8�=G�>ٌ���Q��.;v�f�=���>�7��A�l!�=��G=iա�m�?�$>K\���>��Ka���b�[*���=0t�`��\�B��.�[��>�V�?����{��J>	J�؉�+�x�/�!������=w1���վ-�龗)q�ۢ>�a��S�H>���>F̐>4�O�W���k=M��=������� >v�����a�O=�$;��},�5��<�l�ԧ9=�����=�=�3�P
�<EAV�{�߽�E�t������=�	�!-޽Ɵ���Ͻ,˴<��3�0�r=�l��y�'�_�=��<�'�!����=��=B}?��s�d	��:���?~�>�#6�>�=,��D�H?����ƌU=$�	��Vy��c��!�g��x��$�����)�	=_�>'�?���=}(��}�:����T
��;�^>@�����<����iY�y�>�N�zrW>j c�]@�m���N\?���?�����=E�>`7�����Ƚ�#��=bk�<ݖ�����<�P�e|8��ᘽ��=V S<�Z��e��v�?�0]���<K�s�}>^<+��=�?�=�&0�&��½��'�������j>`�=����=9\+>��4�@q�=T8���O�x�!>e�=>q~#��#�~@����:�C�%>�6Y�@#!�w�<�N��x�w;�����Y������%=�6�I��"��=��;�n>��q��=�K�E$�ŷ=�׵��`�=IlH�`܁;"�*= ��;�B��{�����=.qP�Ư�=��	�v$�!�нq�.��ᠽw��塿tB9�x��=�Ć=������վ��s={='v���-�=Y|��UY��M��!��.J>�Q?�`�!����>� q��Eľ��:��ο�P��J���j�;����'=L�7��v�*ܫ�t���V�d��u��M�_��>m�>lgp=(��+s��������3�=񗬾�qF�Yx)������2���CR�s�<�K�Y��=4[X���=8�!��[o=r~=>��=��a�5���/�h�]�f�<�K�AY������=0R���>b�j�5��=Ĉ�Nݞ=�q{;O�<��m��v��P�׼k$�=o�=�L��>*vٽ41=cMݽ�^?s�O=��o>3ߕ��7�;���W�!���6�=8�=�b�Ih�>�!_�2N �q湾�f��o���m�e�>�Ͻ� ��xVH<�+�<���>cb��S$�>fA��έ���V<�����q�=5e >>�Ͼ+�����N>�J�#���ܗ����=�\2�Z��?�<��b�~	���ʾ!�����IZ�-��{aQ�� `��H�?5k\�:��o�����(���m��ȋ�0�K���ʾߠ�^�J<{}��lᎾ}�����žG�>�$��JR?kR>5�c<GU|�X��<<Ƚ��=*ɽ�彀�h=z&����!�V�=u$���Fu�m���K��Γٽ#�����콀,a�4cN=��ɽ�y�8�a=C岽$#1=�wG��F= !麺�J��3���y�=�@�=�.�<A
>e�>?�L��=�>�4��M�<�k�08o<pY��z�>��	=b?��V����<�=��?�k�x�<�C��z�"Y����=�HϷ��[����=!喾� [����J�|�<��&>�VT�9���3��48H>�p�@y��-p�/;>�n�p�v=/dɽ�v>9��>���B*B�\�N<*�ξ�N"�5{>�U$����P��<e������g��e3Ծ�!��/��<6/�]�Y���<a�S����>�|��g;��D#?s�8��V�����P��ꈐ��� �-�.� ��=�ҽ��z�f��+߽e�,�b����AE��>=*�?��=�i'�����y<���=�A=
C׽δ��0�=�?=�W=����E���l�=~ܜ�%𽳗�{�X�-$�a�۽g=����E��P�V	�^>)���X=��*��i��^�Ľ�<����~=�>"��>S�����L���+���Ž����̕@�cʼ�=�<5�s>��\?���q���`=>t�x��D�=m�?��;�D�(��<�	���M�>%2�J��>:e���^�ΌE�`^��׿��>e��=�Un=p�>-TҾb��cE>�����!L�K�=>�վ����}����+>aP<?��^�0T��'�>�4�=!��>i�	��ה>>�H�>��t=lJt=�XW���9?u�>d{�>�ʵ�Ү�=�٠��9>���<��>�T�=��h>8�?�HѿS����v#��H��f�K��$>�>�،<���LM>(����)?hɋ=l��>=(��5:>^����ƿ>�Ǿg`>
м��g�}���/����@X��z���=@��<�:[�>9�׽�p� )��@�<��@��͇�w4$�L�����0�$с���{�n ��6����@=�4����?<��������ϽhRK�'�L��zc�p��<v�� ����~�+���~ȼ�������6�>�
)�n�ܾ�ѯ�`<
=�0��Z?�v
>�P���U�ߡ��_�����w�>E�-��֙���
��-־Uu�����h ��j|ڽV���v��ei��DQ�HK0��n��fK<�S��[���V�Ͻ�ٽ��a?�f���դ��u?� \>�"�<]=s��i8��C���e��C\>I>����>_�L�S*��E2��2Gb�9B�by��s�;ȑ�=cE��u����f9<3Ĥ?�fO=�%�=�[����̿��ǽ3߼�熿x������G	��P���`S��������cj����"M?�[�>u��<��|<6o�;�Y(�2�}���G���I>��{�
=>%y���=P��=vj¾��k��=f��= �3>���!��?1�.��=.ѩ�I�>�vT>�h=a�O�HЌ� Y��q����=ϐ7=(�<�۽^M�o�J=S�=sN�<ig=&jȿ�c5>x�ܗ]>��<�
���{�Ia潉xҽ����/������ʪ	����<ɤi��a��{]���=0���	�v�����#�\5Z�������g��9����h����8,��"����8z=~Aż�Ck�q/��F�=��"�h���}>���׌��gN�����=kg�=T
)�����^��<:�B�����P� te<�D}��ڥ�?��A���ĥ�=	�b�X��1j7�.�;M��[���1���=W��O^�=�x��/��=y�+�)�(=}\:��bF��]2�(�<�];��1��፽��=j���ʻż)�����=ia��.l=B߼E%���P(�u!>�?8�F��>���\��\�S�,�u=�����������z�kB���������d��>���pC�����ʽ ��B����*�<���H�<�5��j��! D��F�5�5=�k<��}���)>B�x���پm~Y��TF���o>�Xl�頟;�L��A�=Uz2��>�"��s�<�s9>�x���?)w�=,���[��X:w��O�x���B���Ӡ�M��;�%��\�|>��T�e���f`ܽ�k>�絽X!��f��L������Ͼ�'#�=��?��ɿ*�b���սì-=��I?a��8�ݾ���=o���� �W�S?:��=&F���H<���v�<�FV�H>��ͽkY5���0�t>D�/Ҡ�����!>V��>��߾J�>먌�.���r�=#x���ž�i��O�]��.�?7�����ҿ��?:�>�|)>��G����Ͳ�p#i�'�$�`�?=o�m�
?�ؤ�$�I����=�9�R���m��g/��y;�uݾ��v����?;�ȃ��[5ɾa�^��-��NX��ս�w�ϼ��L���Q������]��-`��8J�<�������?1Q�>b�*>�U��ym��u�<z�@�2�u�l�b���D�z���>>ϗ<I�����@=d��8�K��G>����<$͏��⽩t]�R�P�. �=��`�=A >2�����=�R5��������=R���@�$��w��=s㣾ßy=�7��y�F�r�/�;�H���I<�2�=�e��e�6>�� =�uo���̾0�T��hu���)>vG��)�"��=�0�M*�9/)�=Yl��j<7����<O�=���󗲼�dO��W�̘��pu=>O�5�^��<D�o=�Z=�Б���n��F2������B����u�5����>�⺿�Z�y�=�F�<�2>sȣ>i߃��]K>��3�x���!�Y>��Ͼo|>2�Ҿ0`�>'s�����>�����x?�޽Gp-��/�������M/�؝4>�_�>�)���;Ȕ�>�i���a�>�`������"�[��=��*���?:�ϾKs?Lc�>x-P�(       z�{<���񨒽�M?��{�S�?�����?;ܾH>M�>���S�x>SO������R��=�;�>n�H�j'A�v������S*=|��B�����"~��v��FM>�r�>�|���oe=�94=�q��a>�E_���=_��^p�=%m?(       )v�� �ٽRi�����w�g��P����?]���~$�>����ɕ�IϚ?Ro�>����\�'�v�>�"<Jռ�S<5�d>���>���ʐ��\Կj�>�.?jN$?" 滣��>�ʾ��=�?�N6>[�B��E4��J>��%?�~=>\�F���       Qh.�(       �ϝ���8?A�>�ʱ��zx��f��̩�c7>�1�����9_�>m	S����=�f���>|��7�>�ξr9ڿ��?`3���ٿ�݄��c,?����d�����=�?����$>Vٿ9�y�w飿��ݾ,��>�6���ez?�vB?j�=���